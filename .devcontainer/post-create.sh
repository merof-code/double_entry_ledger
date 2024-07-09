if [ -f Gemfile ]; then
    bundle install
fi

if [ -f .ruby-lsp/Gemfile ]; then
    cd .ruby-lsp
    bundle install
fi