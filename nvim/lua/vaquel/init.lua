-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'vaquel.lazy'
require 'vaquel.remap'
require 'vaquel.opt'
require 'vaquel.commands'
require 'vaquel.autocmd'
require 'vaquel.string-manipulation'
require 'vaquel.health'
