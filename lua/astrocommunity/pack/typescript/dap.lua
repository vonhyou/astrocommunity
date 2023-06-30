local utils = require "astronvim.utils"

return {
  "mfussenegger/nvim-dap",
  optional = true,
  config = function()
    local dap = require "dap"
    dap.adapters["pwa-node"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = "node",
        -- 💀 Make sure to update this path to point to your installation
        args = {
          require("mason-registry").get_package("js-debug-adapter"):get_install_path()
            .. "/js-debug/src/dapDebugServer.js",
          "${port}",
        },
      },
    }
    dap.adapters["pwa-node-ts"] = function(cb, config)
      if config.preLaunchTask then
        local async = require "plenary.async"
        local notify = require("notify").async

        async.run(function()
          vim.fn.system(config.preLaunchTask)
          config.type = "pwa-node"
          dap.run(config)
        end)
      end
    end
    local js_config = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      },
    }

    if not dap.configurations.javascript then
      dap.configurations.javascript = js_config
    else
      utils.extend_tbl(dap.configurations.javascript, js_config)
    end
    local ts_config = {
      {
        type = "pwa-node-ts",
        request = "launch",
        name = "Launch file (Typescript)",
        sourceMaps = true,
        preLaunchTask = "tsc --project tsconfig.json",
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**",
        },
        protocol = "inspector",
        skipFiles = { "<node_internals>/**" },
      },
      {
        type = "pwa-node-ts",
        request = "attach",
        name = "Attach",
        processId = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
        sourceMaps = true,
        resolveSourceMapLocations = {
          "${workspaceFolder}/**",
          "!**/node_modules/**",
        },
      },
    }
    if not dap.configurations.typescript then
      dap.configurations.typescript = ts_config
    else
      utils.extend_tbl(dap.configurations.typescript, ts_config)
    end
  end,
}
