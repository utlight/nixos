{
  lib,
  fetchFromGitHub,
  pnpmConfigHook,
  dsh,
}:
dsh.buildDshBundle.fromPnpmWorkspace (finalAttrs: {
  pname = "dsh-acp-enhanced";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "grunmin";
    repo = "dsh-acp-enhanced";
    tag = "v${finalAttrs.version}";
    hash = "sha256-okisHsWKtph28A81eu3ZLgPpu//8Y+LuV3jesSA4KYQ=";
  };

  # 0.11.2 was released for 0.2.1-rc.2. Its preset declarations still mount
  # `@deepseek-ai/dsh-tool-subagent-control/list-agents`, a subpath removed in
  # 0.2.2-rc.3; the row then never starts and `session/new` fails for the
  # default `standard` preset. The main `tool-subagent-control` package
  # registers the same `list_agents` tool on 0.2.2, so drop the stale rows.
  patches = [./dsh-acp-enhanced-0.2.2-list-agents.patch];

  # The package name inside the pnpm workspace, used by the deploy step.
  # Check package.json if "dsh-acp-enhanced" does not match the published name.
  deployPackage = "dsh-acp-enhanced";

  # The builder owns the pnpm fetcher; supply the hash directly.
  pnpmDepsHash = "sha256-5HLbwdc1xPdeO0Mj0H534qhaay5hsBbx6dbfwzhfStk=";

  # The bridge imports the harness packages as peers. `pnpm deploy --prod`
  # drops that metadata from the deployed manifest, so link the installation's
  # copies next to the bundle and let the one module instance be shared.
  installation = dsh.dsh-runtime;

  # The upstream peer range excludes this runtime (0.2.2-rc.3), and the boot
  # gate would skip the whole bundle; engines.dsh decides compatibility alone.
  dshEngines = "0.2.2-rc.3";

  npmDeps = null;
  npmConfigHook = pnpmConfigHook;
  dontNpmBuild = true;

  meta = {
    description = "Enhanced ACP server for DeepSeek Harness (dsh-acp-enhanced)";
    homepage = "https://github.com/grunmin/dsh-acp-enhanced";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
