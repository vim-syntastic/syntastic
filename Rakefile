
TEST_DIR = "test"
SOURCE = "src/coffeelint.coffee"
LIB_DIR = "lib"
LINT_CONFIG = "test/fixtures/fourspaces.json"

# Print a notification.
def notify(message)
  padding = 4
  line = '*' * (message.length + padding)
  puts line
  puts "* #{message.downcase} *"
  puts line
end

desc "Run unit tests."
task :test => [:compile] do
  sh("node_modules/.bin/vows --spec test/*.coffee")
  notify("tested!")
end

desc "Lint the linter."
task :lint => [:compile] do
  sh("./bin/coffeelint -f #{LINT_CONFIG} src/*.coffee test/*.coffee")
  notify("linted!")
end

desc "Compile the source."
task :compile do
  sh("node_modules/.bin/coffee -c -o #{LIB_DIR} #{SOURCE}")
  notify("compiled!")
end

desc "Compile the source when it changes."
task :watch do
  sh("node_modules/.bin/coffee -wc -o #{LIB_DIR} #{SOURCE}")
end

task :default => [:compile, :test, :lint]
