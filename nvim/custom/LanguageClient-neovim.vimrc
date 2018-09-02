" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {
    \ 'rust': ['~/.cargo/bin/rustup', 'run', 'stable', 'rls'],
    \ 'javascript': ['/usr/local/bin/javascript-typescript-stdio'],
    \ 'javascript.jsx': ['tcp://127.0.0.1:2089'],
    \ 'python': ['/usr/local/bin/pyls'],
    \ 'java': [
    \   "/Library/Java/JavaVirtualMachines/jdk1.8.0_181.jdk/Contents/Home/bin/java",
    \   "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    \   "-Dosgi.bundles.defaultStartLevel=4",
    \   "-Declipse.product=org.eclipse.jdt.ls.core.product",
    \   "-Dlog.protocol=true",
    \   "-Dlog.level=NONE",
    \   "-noverify",
    \   "-Xmx1G",
    \   "-jar",
    \   "/Users/liufeng/dotfiles/external/jdt/plugins/org.eclipse.equinox.launcher_1.5.100.v20180827-1352.jar",
    \   "-configuration",
    \   "/Users/liufeng/dotfiles/external/jdt/config_mac",
    \   "-data",
    \   "/Users/liufeng/Code/.jdt_workspace",
    \ ],
    \ }

nnoremap <F5> :call LanguageClient_contextMenu()<CR>
" Or map each action separately
nnoremap <silent> K :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
