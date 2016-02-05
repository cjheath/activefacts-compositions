#
# Enumerate files with "extension" in directories called "path" anywhere in the Ruby LOAD_PATH
#
class Loadable
  def initialize path = "", extension = '.rb'
    @path = path
    @extension = extension
  end

  def enumerate
    $LOAD_PATH.
    flat_map do |dir|
      dir_path = (dir+"/"+@path).gsub(%r{//+}, '/')
      pattern = dir_path+"/**/*"+@extension
      Dir[pattern].
      map do |p|
	p.
	sub(%r{#{Regexp.escape(dir_path)}/}, '').
	sub(%r{#{@extension}}, '')
      end
    end

  end
end

if __FILE__ == $0
  p Loadable.new(*ARGV).enumerate
end
