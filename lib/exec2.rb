# frozen_string_literal: true

require_relative "exec2/version"

# Exec2 provides the pretty much the same interface as Process.spawn, but with
# extra whistles.
class Exec2
  # Error contains information about a process that exited with a non-zero
  # status
  class Error < StandardError
    attr_reader :stdout, :stderr, :status, :cmd, :env

    def initialize(status, stdout, stderr, cmd, env)
      super("Process `#{cmd}' exited with status #{status}: #{stdout} #{stderr}")
      @status = status
      @stdout = stdout
      @stderr = stderr
      @cmd = cmd
      @env = env
    end
  end

  # exec2 executes a given cmd with a set of options, and returns its stdout
  # and stderr output, or raises an error.
  def self.exec2(cmd, **options)
    out_reader, out_writer = IO.pipe
    err_reader, err_writer = IO.pipe
    in_reader, in_writer = IO.pipe

    env = (options.delete(:env) || {}).to_h { |k, v| [k.to_s, v.to_s] }
    options.delete(:chdir) if options.fetch(:chdir, nil).nil?

    env["PATH"] = ENV.fetch("PATH", "") unless env.key? "PATH"

    opts = {
      unsetenv_others: options.delete(:isolate_env) || false,
      out: out_writer.fileno,
      err: err_writer.fileno,
      in: in_reader.fileno
    }.merge options

    pid = if cmd.is_a? Array
      Process.spawn(env, *cmd, **opts)
    else
      Process.spawn(env, cmd, **opts)
    end

    in_writer.close
    mut = Mutex.new
    cond = ConditionVariable.new

    status = nil
    Thread.new do
      _pid, status = Process.wait2(pid)
      mut.synchronize { cond.signal }
    end

    stdout = nil
    stderr = nil
    out_thread = Thread.new { stdout = out_reader.read }
    err_thread = Thread.new { stderr = err_reader.read }
    mut.synchronize { cond.wait(mut, 0.1) } while status.nil?

    out_writer.close
    out_thread.join

    err_writer.close
    err_thread.join

    out_reader.close
    err_reader.close

    raise Error.new(status.exitstatus, stdout, stderr, cmd, env) unless status.success?

    [stdout, stderr]
  end

  # exec behaves just like exec2, but only returns stdout
  def self.exec(cmd, **options)
    exec2(cmd, **options).first
  end
end
