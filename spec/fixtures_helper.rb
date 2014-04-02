FIXTURES_DIR = File.dirname(__FILE__) + '/fixtures'

def robot_txt(name)
  File.read("#{FIXTURES_DIR}/#{name}.txt")
end
