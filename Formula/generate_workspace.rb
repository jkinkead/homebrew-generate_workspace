class GenerateWorkspace < Formula
  desc 'generate_workspace tool for Bazel.'
  homepage 'https://github.com/bazelbuild/migration-tooling'
  # TODO(jkinkead): Fix this to point at a real release.
  url 'https://github.com/bazelbuild/migration-tooling.git',
      :revision => 'cc88b8da996c222a3819aa006e795b68dbe983bd'
  revision 1

  depends_on 'bazel' => :build

  def install
    system 'bazel', 'build', 'generate_workspace'
    bin.install 'bazel-bin/generate_workspace/generate_workspace' => 'generate_workspace'
  end

  test do
    ENV['JAVA_RUNFILES'] = 0
    system 'generate_workspace'
  end
end
