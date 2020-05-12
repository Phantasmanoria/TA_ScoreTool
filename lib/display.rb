# coding: utf-8

class Display < Col

  def self.conf(opt, err=[])
    cputs ["CONFIG LIST(default:green, modify:blue, error:red)", 3] # 表題
    cputs ["-"*`tput cols`.chomp.to_i, 3] # 端末一面の横線
    cputs [["|",3],["option".ljust(20),3],["|",3],["value".ljust(40),3], ["|",3]]
    cputs ["-"*`tput cols`.chomp.to_i, 3]
    opt = Convert.opt_expand(opt)
    opt.each do |key, value| # 中身の表示
      key = key.to_s
      value = "false" if value.empty?
      if err.include?(key) # エラー候補なら赤表示
        cputs [["|",3],[key.ljust(20),0],["|",3],[value.ljust(40),0],["|",3]]
      elsif comp(key,value) # defaultと同じなら緑表示
        cputs [["|",3],[key.ljust(20)],["|",3],[value.ljust(40)],["|",3]]
      else # defaultと異なるなら青表示
        cputs [["|",3],[key.ljust(20),1],["|",3],[value.ljust(40),1],["|",3]]
      end
    end
    
    cputs ["-"*`tput cols`.chomp.to_i, 3]

    exit 1 if err.length != 0 # エラー終了
    
  end

  
  def self.comp(key,val1) # default比較
    default={"config_file" => "config.yml",
             "mode" => "NONE",
             "input_folders" => "[\"in\"]",
             "output_folder" => File.expand_path("out"),
             "log" => "false",
             "classification" => "[\"NONE\"]",
             "size" => "NONE",
             "date" => "NONE",
             "move" => "false"
            }
    val2 = eval("default['#{key}']")
    val2 == val1
  end


  def self.file_list(lists)
    cputs ["FILE LIST", 3] # 表題    
    cputs ["-"*`tput cols`.chomp.to_i, 3]
    cputs [["|",3],["path".ljust(40),3],["|",3],["size".ljust(6),3],["|",3],["ext".ljust(10),3],["|",3],["modify time".ljust(19),3],["|",3]]
    cputs ["-"*`tput cols`.chomp.to_i, 3]
    
    lists.each do |file, tmp, info| # 中身表示
      cputs [["|",3],[Convert.str_reduct(file,40)],["|",3],[Convert.num_byte(info.size.to_s).rjust(6)],
             ["|",3],[Convert.str_ext(file).rjust(10)],["|",3],[info.mtime.strftime("%Y/%m/%d %H:%M:%S")],["|",3]]
    end
    
    cputs ["-"*`tput cols`.chomp.to_i, 3]
  end

  
end






