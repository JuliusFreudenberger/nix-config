{config, pkgs, ...}: {

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;
    coc.enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-gitgutter
      markdown-preview-nvim
      tabular
      vim-markdown
      vimtex
      nvim-lspconfig
      typst-vim
    ];

    extraConfig = ''
      set number
      set relativenumber
      set termguicolors
      set expandtab
      set shiftwidth=2
      set linebreak
      
      :augroup numbertoggle
      :  autocmd!
      :  autocmd BufEnter,FocusGained,InsertLeave * set relativenumber
      :  autocmd BufLeave,FocusLost,InsertEnter   * set norelativenumber
      :augroup END

      let g:vimtex_view_method = 'zathura'
      let g:coc_filetype_map = {'tex': 'latex'}
    '';
  };

}
