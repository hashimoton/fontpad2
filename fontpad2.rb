# coding: utf-8
# fontpad2.rb

require "tk"
require "fiddle/import"
require "fiddle/types"
require "ttfunk"

require "pp"


module Win32API
  extend Fiddle::Importer
  dlload 'gdi32.dll'
  include Fiddle::Win32Types
  extern 'int AddFontResourceEx(LPCSTR, DWORD, PVOID)'
  extern 'int RemoveFontResourceEx(LPCSTR, DWORD, PVOID)'
  
end



class FontLoader
  FR_PRIVATE = 0x10
  
  PLATFORMS = ["Unicode", "Macintosh", "Reserved", "Microsoft"]
  
  def initialize
    @font_file_path = ""
  end

  def load(font_file_path)
    if !@font_file_path.empty?
     Win32API::RemoveFontResourceEx(@font_file_path, FR_PRIVATE, 0)
    end
    
    @font_file_path = font_file_path
    begin
      @font_file = TTFunk::File.open(@font_file_path)
    rescue => e
      @font_file_path = ""
      return 0
    end
    return Win32API::AddFontResourceEx(@font_file_path, FR_PRIVATE, 0)
  end


  def unload
    return Win32API::RemoveFontResourceEx(@font_file_path, FR_PRIVATE, 0)
  end


  # Rough decode assuming that all stringsare encoded in UTF-16BE except for Mac+Roman
  # https://developer.apple.com/fonts/TrueType-Reference-Manual/RM06/Chap6name.html
  def to_utf8(raw_text)
    if raw_text.platform_id == 1 && raw_text.encoding_id == 0
      return raw_text
    else
      begin
        raw_text.encode("UTF-8", "UTF-16BE")
      rescue
        raw_text
      end
    end
  end

  def names
    name_table = @font_file.name
    font_name = name_table.font_name
    font_name.each do |s|
      puts "PL#{s.platform_id},EC#{s.encoding_id},LN#{s.language_id},#{s.inspect}"
    end
    
    names = font_name.map do |raw_name|
      {
        platform: PLATFORMS[raw_name.platform_id],
        encoding: raw_name.encoding_id,
        language: raw_name.language_id,
        text: to_utf8(raw_name)
      }
    end
    
    return names
  end
  
  
  def families
    name_table = @font_file.name
    font_family = name_table.font_family
    font_family.each do |s|
      puts "PL#{s.platform_id},EC#{s.encoding_id},LN#{s.language_id},#{s.inspect}"
    end
    
    families = font_family.map do |raw_name|
      {
        platform: PLATFORMS[raw_name.platform_id],
        encoding: raw_name.encoding_id,
        language: raw_name.language_id,
        text: to_utf8(raw_name)
      }
    end
    
    return families
  end

end


class FontPad2
  FONT_DEFAULT_SIZE = 12

  attr_accessor :font_loader, :window, :text
  
  def initialize(options = {})
    window_options =
    {
      title: self.class.to_s,
      geometry: "320x240"
    }
    window_options.merge!(options)
    @window = TkRoot.new(window_options)
  end

  def run(font_file_path = "")
    @font_loader = FontLoader.new
    layout
    open_font(font_file_path)
    
    Tk.mainloop
    @font_loader.unload
  end
  
  def open_font(font_file_path)
    puts font_file_path
    if font_file_path.nil? || font_file_path.empty?
      @text.value = "Select a font file"
    else
      loaded_count = @font_loader.load(font_file_path)
      
      if loaded_count > 0
        font_names = @font_loader.names
        name_text = font_names.map do |name|
          "  #{name[:platform]}: '#{name[:text]}'"
        end.join("\n")
        family_text = @font_loader.families.map do |name|
          "  #{name[:platform]}: '#{name[:text]}'"
        end.join("\n")
        
        @text.value = "File:\n  #{font_file_path.encode('utf-8')}\n\n" +
          "Name:\n#{name_text}\n\n" +
          "Family:\n#{family_text}\n"
        @text.font = TkFont.new(family: font_names.first[:text],
          size: FONT_DEFAULT_SIZE, weight: :normal)
      else
        @text.value = "Can't load #{font_file_path}"
      end
    end
  end
  
  
  def layout
    toolbar = TkFrame.new.pack(side: 'top', fill: 'x')

    @text = TkText.new do
      yscrollbar(TkScrollbar.new.pack(fill: 'y', side: 'right'))
      pack(side: 'left', fill: 'both')
    end

    mb_open = TkButton.new(toolbar) do
      text 'Open'
      pack(side: 'left')
    end.command do
      file_path = Tk.getOpenFile
      if !file_path.nil? && !file_path.empty?
        open_font(file_path)
      end
    end

    mb_increase= TkButton.new(toolbar) do
      text '+'
      pack(side: 'left')
    end.command {@text.font.size = [@text.font.size + 2, 64].min}
    
    mb_reset = TkButton.new(toolbar) do
      text 'o'
      pack(side: 'left')
    end.command { @text.font.size = FONT_DEFAULT_SIZE }

    mb_decrease = TkButton.new(toolbar) do
      text '-'
      pack(side: 'left')
    end.command {@text.font.size = [@text.font.size - 2, 2].max}
  end
end


font_file_path = ARGV[0]
FontPad2.new.run(font_file_path)

# EOF
