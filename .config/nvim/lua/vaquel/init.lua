-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

utils = require 'vaquel.utils'
require 'vaquel.lazy'
require 'vaquel.keymap'
require 'vaquel.opt'
require 'vaquel.commands'
require 'vaquel.autocmd'
require 'vaquel.string-manipulation'
require 'vaquel.health'
