# Load everything from bundle console

$LOAD_PATH << File.expand_path(".")

Dir["app/models/*.rb"].each { |file| require file }
