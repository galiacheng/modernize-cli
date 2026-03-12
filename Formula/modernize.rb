class Modernize < Formula
  desc "AI-powered CLI for application modernization"
  homepage "https://github.com/galiacheng/modernize-cli"
  version "0.0.225"

  if OS.mac?
    if Hardware::CPU.intel?
      url "https://github.com/galiacheng/modernize-cli/releases/download/v0.0.225/modernize_0.0.225_darwin_x64.tar.gz"
      sha256 "9f6895a879bd251ebefd790470d2d8c9b7777ee1557c83222ad2c5d639779935"
    elsif Hardware::CPU.arm?
      url "https://github.com/galiacheng/modernize-cli/releases/download/v0.0.225/modernize_0.0.225_darwin_arm64.tar.gz"
      sha256 "fca6dd93ccce3d91104f0ae19f1dafb49c2b800ce4baca46d38cbdc71d35c8b8"
    end
  elsif OS.linux?
    if Hardware::CPU.intel?
      url "https://github.com/galiacheng/modernize-cli/releases/download/v0.0.225/modernize_0.0.225_linux_x64.tar.gz"
      sha256 "f6a270e65140276cbeb3437323ca187158de251ce49bc9b2eb519a9a6bec64da"
    elsif Hardware::CPU.arm?
      url "https://github.com/galiacheng/modernize-cli/releases/download/v0.0.225/modernize_0.0.225_linux_arm64.tar.gz"
      sha256 "d75ed588814b2271efc507ffb7ddef6a99588a2ccec972793c979ac56f1c52e7"
    end
  end

  license "Proprietary"

  def install
    libexec.install "modernize"
    libexec.install "runtimes"
    bin.install_symlink libexec/"modernize"
  end

  test do
    version_output = shell_output "#{bin}/modernize --version"
    assert_equal 0, $CHILD_STATUS.exitstatus
    assert_match "modernize", version_output
  end
end

