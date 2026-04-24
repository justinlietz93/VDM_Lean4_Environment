# Handoff: from zip to live green badge

This is the concrete sequence. End state: a public GitHub repo with three green Lean
badges that any paper's `CLOSURE_CERTIFICATE.md` can link to.

Estimated total time (wall clock): **20 minutes.** Estimated Acer CPU time: **zero.**

## 1. Create the repo on GitHub

Go to github.com/new. Suggested settings:

- Name: `vdm-lean-certifier` (or whatever fits your naming)
- Visibility: **Public** (required for free Actions minutes and gh-pages badges)
- Do NOT initialize with README, license, or .gitignore — you have them locally

## 2. Push this bundle

From wherever you unzipped this:

```bash
cd vdm-lean-certifier
git init -b main
git add .
git commit -m "chore: initial VDM Lean certifier scaffold"
git remote add origin https://github.com/<your-user-or-org>/vdm-lean-certifier.git
git push -u origin main
```

## 3. First CI run kicks off automatically

Go to the repo's **Actions** tab. You will see a `build` workflow running. The
first cold run will take ~3-5 minutes per package (Lean toolchain download,
no mathlib to compile). Every subsequent run on the same package+toolchain
combination hits the cache and finishes in under a minute.

### Expected outcome

All three packages (`PCVDMLiftedCore`, `PCVDMLiftedDescent`, `HeadToHeadEML`)
go green. If any fails, click into the job and read the log — these proofs
have been eyeballed but not yet fired against real Lean, so one-off syntax
or tactic-name drift against the 4.21.0 toolchain is possible. Ping me with
the red build log and I'll patch.

## 4. Enable GitHub Pages (one-time setup for badges)

The first push triggers a build on main, which publishes badge JSONs to a
new `gh-pages` branch. Once that branch exists:

1. Settings -> Pages
2. Source: **Deploy from a branch**
3. Branch: **gh-pages**, folder: `/ (root)`
4. Save

Within ~30 seconds, `https://<you>.github.io/vdm-lean-certifier/PCVDMLiftedCore.json`
is live. The shields.io badge URLs in `README.md` and `VERIFICATION_INDEX.md`
will render immediately after.

## 5. Update the `REPLACE_ME` placeholder

Edit `README.md` and replace `REPLACE_ME` in the shields.io badge URLs with
your actual GitHub username or org name. One-liner if you want:

```bash
sed -i 's/REPLACE_ME/<your-user-or-org>/g' README.md
git commit -am "docs: point badges at real gh-pages host"
git push
```

## 6. Verify from the outside

Open an incognito window. Load the repo README. You should see three green
Lean badges with theorem counts. If a skeptic clicks a badge, shields.io
fetches the live JSON from your gh-pages and renders it. If the underlying
build ever breaks, the badge turns red within one CI run.

This is the artifact your future `CLOSURE_CERTIFICATE.md` files link to.

## 7. First real paper linkage

In your next VDM/PC bundle's `CLOSURE_CERTIFICATE.md`, replace the
"Lean/Lake was not installed locally" disclaimer with:

```markdown
## Lean 4 mechanical verification

The theorem surface for this paper lives in package `<PackageName>` of
[vdm-lean-certifier](https://github.com/<you>/vdm-lean-certifier). Current
build status: ![<PackageName>](https://img.shields.io/endpoint?url=https://<you>.github.io/vdm-lean-certifier/<PackageName>.json).

SHA256 of the latest released `.olean` bundle: `<sha>` (see the release
assets at https://github.com/<you>/vdm-lean-certifier/releases).
```

That replaces "source-only" with "green-checked on every commit against a
pinned Lean toolchain, SHA-verified build artifacts available." Skeptic
options narrow to zero.

## 8. Adding new packages

When CF15 (Noether rewrite) is ready, or the CF09 non-abelian extension,
or any future theorem surface:

```bash
scripts/new_package.sh <NewPackageName>
# paste the Lean source into packages/<NewPackageName>/<NewPackageName>/Basic.lean
git add packages/<NewPackageName>
git commit -m "lean: <brief description>"
git push
```

The new package shows up as a new badge after one CI run. No workflow edits.
No matrix-list updates. Discovery is glob-driven.

## 9. Tagged releases (optional but recommended)

When a paper ships, cut a release:

```bash
git tag v0.1.0                   # match your paper's DOI revision
git push --tags
```

This triggers the release workflow: rebuilds everything, bundles .olean files
per package, emits `VERIFICATION_INDEX.md` with commit SHA and build timestamp,
computes SHA256 manifest, publishes a GitHub Release with all of the above
attached. That release is the citable immutable artifact.

## Troubleshooting

- **Build fails with "toolchain not found":** The runner couldn't fetch Lean
  4.21.0 from releases.lean-lang.org. Usually transient. Click "Re-run jobs"
  in the Actions UI.
- **Build fails on a theorem:** Open the failing package's `Basic.lean`,
  inspect the tactic that broke. Most likely causes, in order:
  1. Tactic name drift (Lean core rename since 4.21.0).
  2. Missing `import Mathlib.XXX` for a lemma we assumed was in core.
  3. A structural mistake in the proof (rare; these were reviewed).
- **Pages not publishing badges:** Confirm Settings -> Pages points at the
  `gh-pages` branch. Confirm the `publish-badges` job ran on the `main` push.
  It only runs on pushes to main, not PRs.
- **Public repo gives free unlimited Actions minutes for public repos** — this
  will not cost you money.

## What this buys you, stated plainly

1. A permanent, public, mechanized endpoint that certifies VDM/PC theorems.
2. Every paper you ship from now on links to a badge, not a disclaimer.
3. The Acer never compiles Lean again. Codespaces or GitHub runners do it.
4. Three extra lines of shell (`scripts/new_package.sh <N>`; git add/commit/push)
   add a new theorem surface forever after.

That is the instrument. Keep it simple, keep it boring, keep it green.
