class MonthlyPlan < Formula
  desc "Monthly calendar with Google Calendar, places, image export, and Supabase sync"
  homepage "https://github.com/kube-guy/monthly-plan"
  url "https://github.com/kube-guy/monthly-plan/archive/refs/tags/v0.1.7.tar.gz"
  sha256 "601520004a25978d1aa657505dae5b5584213ecd43199805cd44c53cd0be5064"
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
      Google account sign-in needs a configured Supabase Google provider.
      Direct Google Calendar connection needs a Google Cloud Desktop OAuth client.
      See the Google setup guides in the monthly-plan repository.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/monthly-plan --version")
  end
end
