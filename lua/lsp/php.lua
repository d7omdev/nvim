---@type table<string, vim.lsp.Config>
return {
  phpantom = {
    cmd = { vim.fn.expand("~/.local/bin/phpantom_lsp") },
    filetypes = { "php" },
    root_markers = { "composer.json", ".git" },
  },

  intelephense = {
    filetypes = { "php", "blade" },
    get_language_id = function(_, filetype)
      return filetype == "blade" and "php" or filetype
    end,
    settings = {
      intelephense = {
        environment = {
          phpVersion = (vim.fn.system("php -r 'echo PHP_MAJOR_VERSION.\".\".(PHP_MINOR_VERSION);'")):match("^%d+%.%d+") or "8.0",
        },
        stubs = {
          "apache", "bcmath", "bz2", "calendar", "com_dotnet", "Core", "curl",
          "date", "dba", "dom", "enchant", "exif", "FFI", "fileinfo", "filter",
          "fpm", "ftp", "gd", "gettext", "gmp", "hash", "iconv", "imap",
          "intl", "json", "ldap", "libxml", "mbstring", "meta", "mysqli",
          "oci8", "odbc", "openssl", "pcntl", "pcre", "PDO", "pdo_ibm",
          "pdo_mysql", "pdo_pgsql", "pdo_sqlite", "pgsql", "Phar", "posix",
          "pspell", "random", "readline", "Reflection", "session", "shmop",
          "SimpleXML", "snmp", "soap", "sockets", "sodium", "SPL", "sqlite3",
          "standard", "superglobals", "sysvmsg", "sysvsem", "sysvshm",
          "tidy", "tokenizer", "xml", "xmlreader", "xmlrpc", "xmlwriter",
          "xsl", "Zend OPcache", "zip", "zlib",
        },
        files = { maxSize = 5000000 },
        storage = {
          storagePath = vim.fn.stdpath("data") .. "/intelephense",
        },
        -- licenceKey = "",
      },
    },
  },
}
