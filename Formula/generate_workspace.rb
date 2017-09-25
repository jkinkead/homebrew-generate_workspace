class GenerateWorkspace < Formula
  desc 'generate_workspace tool for Bazel.'
  homepage 'https://github.com/bazelbuild/migration-tooling'
  # TODO(jkinkead): Fix this to point at a real release.
  url 'https://github.com/bazelbuild/migration-tooling.git',
      :revision => 'cc88b8da996c222a3819aa006e795b68dbe983bd'
  revision 1
  version '0.0.2'

  depends_on 'bazel' => :build
  depends_on :java

  def install
    # Build the deploy jar, so that we have an item to copy out.
    system 'bazel', 'build', 'generate_workspace:generate_workspace_deploy.jar'
    # This must have the same prefix as the deploy jar. We leave it the same for simplicity.
    libexec.install 'bazel-bin/generate_workspace/generate_workspace' => 'generate_workspace'
    libexec.install 'bazel-bin/generate_workspace/generate_workspace_deploy.jar' => 'generate_workspace_deploy.jar'

    # Generate a wrapper script that actually works.
    wrapper = libexec/'generate_workspace_wrapper.sh'
    wrapper.write <<-EOS.undent
      #!/bin/bash --posix

      # Suppress looking for runfiles. This is required for --singlejar to work.
      export JAVA_RUNFILES=1
      # Set JAVABIN to system java.
      if [[ -e "$JAVA_HOME/bin/java" ]]; then
        export JAVABIN="$JAVA_HOME/bin/java"
      else
        export JAVABIN=$(which java)
      fi

      # Resolve all symlinks.
      SCRIPT="$0"
      while true; do
        if [[ ! -L "$SCRIPT" ]]; then
          break
        fi
        readlink="$(readlink "$SCRIPT")"
        if [[ "$readlink" = /* ]]; then
          SCRIPT="$readlink"
        else
          # resolve relative symlink
          SCRIPT="${SCRIPT%/*}/$readlink"
        fi
      done
      TARGET=$(dirname $SCRIPT)/generate_workspace
      exec "$TARGET" --singlejar "${ARGS[@]}"
    EOS
    wrapper.chmod(0755)
    # Symlink the wrapper as the main name.
    bin.install_symlink wrapper => 'generate_workspace'
  end

  test do
    system '#{bin}/generate_workspace'
  end
end
