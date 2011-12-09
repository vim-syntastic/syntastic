
TEST_DIR = "test"
SOURCE = "src/coffeelint.coffee"
LIB_DIR = "lib"
LINT_CONFIG = "test/fixtures/fourspaces.json"

desc "Run unit tests."
task :test => [:compile] do
  sh("vows --spec test/*.coffee")
end

desc "Lint the linter."
task :lint => [:compile] do
  sh("./bin/coffeelint -f #{LINT_CONFIG} src/*.coffee test/*.coffee")
end

desc "Compile the source."
task :compile do
  sh("coffee -c -o #{LIB_DIR} #{SOURCE}")
end

desc "Compile the source when it changes."
task :watch do
  sh("coffee -wc -o #{LIB_DIR} #{SOURCE}")
end

desc "Create a distribution."
task :dist => [:compile, :test, :lint]

