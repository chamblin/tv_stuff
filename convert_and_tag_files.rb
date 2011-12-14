files_to_convert_directory = "/Users/Cory/Downloads/sickbeard"
output_directory = "/Users/Cory/Downloads/Converted TV Shows"
valid_regexes = [/.avi$/i, /.mkv$/i]

require 'fileutils'

files = Dir.glob("#{files_to_convert_directory}/*/*").select{|f| valid_regexes.any?{|r| f =~ r}}

class TVShowFileProcessor
  attr_reader :filename, :output_directory
  def initialize(filename, output_directory=".")
    @filename = filename
    @output_directory = output_directory
  end
  
  def base_filename
    File.basename(filename)
  end
  
  def without_extension
    File.basename(base_filename, File.extname(base_filename))
  end
  
  def output_file(extension=".m4v")
    File.join(output_directory, without_extension + extension)
  end
  
  def show_name
    episode_data[0]
  end
  
  def season_number
    episode_data[1]
  end
  
  def episode_number
    if episode_data[3]
      episode_data[2] + episode_data[3]
    else
      episode_data[2]
    end
  end
  
  def episode_name
    episode_data[4]
  end
  
  def episode_data
    @episode_data ||= without_extension.scan(/(.*?) - (\d+)x(\d+)(-\d+)? - (.*)/)[0]
  end
  
  def convert_to_m4v!
    command = "HandBrakeCLI --preset=\"AppleTV 2\" -v -i \"%s\" -o \"%s\"" % [filename, output_file]
    `#{command}`
  end
  
  def tag_the_m4v!
    command = "AtomicParsley \"%s\" --overWrite --TVShowName \"%s\" --TVSeasonNum \"%s\" --TVEpisode \"%s\" --TVEpisodeNum \"%s\" --stik \"TV Show\"" % [output_file, show_name, season_number, episode_name, episode_number]
    `#{command}`
  end
  
  def delete_the_original!
		FileUtils.touch(filename)
    File.rename(filename, filename + ".processed")
  end
end

files.each do |input_file|
  t = TVShowFileProcessor.new(input_file, output_directory)
  t.convert_to_m4v!
  t.tag_the_m4v!
  t.delete_the_original!
end
