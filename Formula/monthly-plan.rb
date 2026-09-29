class MonthlyPlan < Formula
  desc "Monthly calendar with places, image export, and Supabase sync"
  homepage "https://github.com/kube-guy/monthly-plan"
  url "https://github.com/kube-guy/monthly-plan/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "1e64cf77e79480ab2295fc8fdb44e4b726721bbb214d70d02566e104f8222642"
  license "MIT"
  head "https://github.com/kube-guy/monthly-plan.git", branch: "main"

  depends_on macos: :sonoma

  def install
    system "swift", "build", "--disable-sandbox", "-c", "release",
           "--product", "monthly-plan", "--scratch-path", buildpath/".build"
    system "bash", "scripts/package-app.sh", "--skip-build"
    libexec.install "build/Monthly Plan.app"

    (bin/"monthly-plan").write <<~SH
      #!/bin/bash
      app="#{libexec}/Monthly Plan.app"
      if [[ "${1:-}" == "--version" || "${1:-}" == "--export-empty" || "${1:-}" == "--summarize-place" ]]; then
        exec "$app/Contents/MacOS/monthly-plan" "$@"
      fi
      exec /usr/bin/open -a "$app" --args "$@"
    SH
    (bin/"monthly-plan").chmod 0755
  end

  def caveats
    <<~EOS
      Launch the app with `monthly-plan`.
      To sync between Macs, connect your Supabase project in the app and add
      monthly-plan://auth/callback?state=* to its Authentication redirect URLs.
      For automatic place summaries, install Codex CLI (`brew install --cask codex`)
      and sign in with `codex login` on each Mac.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/monthly-plan --version")
  end
end
