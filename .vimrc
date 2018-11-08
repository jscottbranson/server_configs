"------------------------------------------------------------------------------
"General Settings

"Convenience Options
set encoding=utf-8			"Use utf-8 as default encoding
set t_Co=256				"Enable 256 bit color
set background=dark			"Tells Vim that the background color is black
filetype indent plugin on	"Automatic detection, indenting, and highlighting based on file type
syntax enable				"Turns on syntax highlighting
set nocompatible			"Use Vim defaults
set wildmenu				"Automatically complete :commands by pressing tab
set cmdheight=2				"Set the command line height to two lines
set number					"Always show the line numbers.
set relativenumber			"Show relative line numbers.
set showmatch				"Briefly jump to matching bracket when a new one is inserted

"Spell Check
set spell					"Enable spell check
hi clear SpellBad			"Don't highlight misspelled words
hi SpellBad cterm=underline,bold ctermfg=red "Changes misspelled words to underlined, bold, red text

"Searching
set wrapscan				"Continue searching at top of document after bottom is reached
set hlsearch				"Highlights all instances of searched string
set incsearch				"Highlights search results while typing
set ignorecase				"Case insensitive searching
set smartcase				"Case sensitive searching when search string has upper case
set infercase				"Fixes the case of automatically completed keywords

"Default tabs, indents, and wrapping
set linebreak				"Lines break at spaces instead of mid-word
set autoindent				"Automatically indent lines
set copyindent				"Auto-indent is based on the format from the previous line
set shiftwidth=4			"Number of characters used for an auto-indent
set tabstop=4				"Number of characters that a tab is displayed as

"Enable folding & set space to control folding
set foldmethod=indent
set foldlevel=99
nnoremap <space> za

"------------------------------------------------------------------------------
"Settings for Specific File Types
"au is an autocommand that watches for events (FileType) that match patterns
	"(html) then runs a particular command (setlocal ...)

"HTML
au FileType html,css setlocal tabstop=2 softtabstop=2 shiftwidth=2 tw=80

"Python
au FileType py setlocal tabstop=4 softtabstop=4 shiftwidth=4 tw=80

"R
"
"To run R outside of nvim's terminal emulator
"let R_in_buffer = 0
"
"Turn Spelling off in R
au Filetype r set nospell
