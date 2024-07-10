local ori_win = 0
local ori_w = 0
local ori_h = 0

local function save_window_size()
  ori_win = vim.api.nvim_get_current_win()
  ori_w = vim.api.nvim_win_get_width(ori_win)
  ori_h = vim.api.nvim_win_get_height(ori_win)
end

local function maximize_current_window()
  vim.cmd([[wincmd _ | wincmd |]])
end

vim.api.nvim_create_user_command("WinMaxToggle", function()
  local current_win = vim.api.nvim_get_current_win()

  if ori_win == 0 then
    save_window_size()
    maximize_current_window()
  else
    if ori_win == current_win then
      vim.api.nvim_win_set_width(ori_win, ori_w)
      vim.api.nvim_win_set_height(ori_win, ori_h)
      ori_win = 0
      ori_w = 0
      ori_h = 0
    else
      if vim.api.nvim_win_is_valid(ori_win) then
          vim.api.nvim_win_set_width(ori_win, ori_w)
          vim.api.nvim_win_set_height(ori_win, ori_h)
      end
      save_window_size()
      maximize_current_window()
    end
  end

end, { nargs = "?", range = false, desc = "最大化、还原window" })
