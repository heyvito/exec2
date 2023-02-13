# frozen_string_literal: true

RSpec.describe Exec2 do
  subject { described_class }

  it "has a version number" do
    expect(Exec2::VERSION).not_to be nil
  end

  it "executes a command" do
    pwd = subject.exec(%w[git rev-parse --show-toplevel]).strip
    stdout, stderr = subject.exec2("spec/helpers/exec_helper --exec-helper-output-on-stderr")
    parsed = ExecSpecParser.parse(stdout)
    path = parsed.delete(:env)["PATH"].split(":")
    expect(parsed).to eq({
      exec: "/bin/bash",
      shell: user_shell,
      args: %w[spec/helpers/exec_helper --exec-helper-output-on-stderr],
      pwd: pwd
    })

    expect(path).to include("/bin")
    expect(stderr.strip).to eq "something on stderr"
  end

  it "raises ExecutionError on error" do
    pwd = subject.exec("git rev-parse --show-toplevel").strip
    ex = nil
    begin
      subject.exec2("spec/helpers/exec_helper --exec-helper-output-on-stderr --exec-helper-exit-1")
    rescue Exec2::Error => e
      ex = e
    end

    expect(ex).not_to be_nil
    expect(ex.cmd).to eq "spec/helpers/exec_helper --exec-helper-output-on-stderr --exec-helper-exit-1"
    expect(ex.env["PATH"].split(":")).to include "/bin"
    expect(ex.status).to eq 1
    expect(ex.stderr.strip).to eq "something on stderr"

    parsed = ExecSpecParser.parse(ex.stdout)
    path = parsed.delete(:env)["PATH"].split(":")
    expect(parsed).to eq({
      exec: "/bin/bash",
      shell: user_shell,
      args: %w[spec/helpers/exec_helper --exec-helper-output-on-stderr
               --exec-helper-exit-1],
      pwd: pwd
    })

    expect(path).to include("/bin")
  end
end
