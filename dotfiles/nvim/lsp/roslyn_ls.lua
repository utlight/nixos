return {
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = false,
      },
    },
  },
  cmd = { "roslyn-language-server", "--stdio" },
  cmd_env = {
    VSToolsPath = "/mnt/windows/Program Files/Microsoft Visual Studio/18/Community/MSBuild/Microsoft/VisualStudio/v18.0/",
    FrameworkPathOverride = "/mnt/windows/Program Files (x86)/Reference Assemblies/Microsoft/Framework/.NETFramework/v4.8",
    SkipEnsureBindingRedirects = "true",
  },
}
