describe("gogentest", function()
  local gogentest

  before_each(function()
    -- Clear any previous plugin state
    vim.g.loaded_gogentest = nil
    -- Reload the plugin
    package.loaded["gogentest"] = nil
    gogentest = require("gogentest")
  end)

  describe("generate", function()
    it("should reject non-Go files", function()
      -- Mock the buffer name to be a non-Go file
      vim.api.nvim_buf_get_name = function()
        return "test.lua"
      end
      
      local notified = false
      vim.notify = function(msg)
        notified = true
        assert.equals("not a Go file", msg)
      end
      
      gogentest.generate()
      assert.is_true(notified)
    end)

    it("should handle Go files", function()
      -- Mock the buffer name to be a Go file
      vim.api.nvim_buf_get_name = function()
        return "main.go"
      end
      
      -- Mock get_current_line to return a function declaration
      vim.api.nvim_get_current_line = function()
        return "func TestFunction() error {"
      end
      
      -- Mock file operations
      vim.fn.filereadable = function()
        return 0
      end
      
      local written = false
      vim.fn.writefile = function(content, path)
        written = true
        assert.equals("main_test.go", path)
        assert.is_table(content)
        return 0
      end
      
      -- Mock vim.cmd
      vim.cmd = function() end
      
      -- Mock vim.notify
      local notified = false
      vim.notify = function(msg)
        notified = true
        assert.truthy(msg:match("generated test for"))
      end
      
      gogentest.generate()
      assert.is_true(written)
      assert.is_true(notified)
    end)
  end)
end)