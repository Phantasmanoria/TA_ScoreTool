# coding: utf-8
require "colorize"

class Col # カラー描写(カーネル上書きは継承のためしていない)
  def cprint(words)
    words = [words, "green"] if words.kind_of?(String) # 文字のみはgreen処理
    words = [words] if words[0].kind_of?(String) # 一次元配列は二次元変換
    for word,color in words
      color = Convert.num_color(color) if color.kind_of?(Integer) # 色数字変換
      color = "green" if color.nil?
      eval("print word.colorize(:#{color})")
    end
  end
  def cputs(words)
    cprint(words)
    puts 
  end
  def cgets
    cprint([">>",5])
    res = gets
    res.chomp
  end
  def cerr(word)
    eval("STDERR.print word.colorize(:red)"); puts
  end
  
  def self.cprint(words)
    words = [words, "green"] if words.kind_of?(String) # 文字のみはgreen処理
    words = [words] if words[0].kind_of?(String) # 一次元配列は二次元変換
    for word,color in words
      color = Convert.num_color(color) if color.kind_of?(Integer) # 色数字変換
      color = "green" if color.nil? 
      eval("print word.colorize(:#{color})")
    end
  end
  def self.cputs(words)
    cprint(words)
    puts
  end
  def self.cgets
    cprint([">>",5])
    res = gets
    res.chomp
  end
  def self.cerr(word)
    eval("STDERR.print word.colorize(:red)"); puts
  end
end



class Convert # 小規模の変換等の機能の格納

  def self.num_str(num,s) # 数字 -> 各文字
    list = [["SCORE", "CONF", "QUIT"],
            ['YEAR','MONTH','DAY','HOUR','MINUTE'],
            ['EXT','SIZE','DATE']]
    list = list[s]
    if num.to_i >=1 && num.to_i <= list.length
      eval("list[#{num.to_i-1}]")
    else nil
    end    
  end
  
  def self.num_mode(num) # 数字 -> モード
    num_str(num,0)
  end
=begin
  def self.num_date(num) # 数字 -> 時間単位
    num_str(num,1)
  end

  def self.num_class(num) # 数字 -> 分類方法
    num_str(num,2)
  end
=end

  def self.num_color(num) # 数字 -> 色
    if num.to_i >=0 && num.to_i <=8
      #        0     1      2       3        4         5       6       7      8
      list = ["red","blue","green","yellow","magenta","white","black","cyan","default"]
      eval("list[#{num.to_i}]")
    else nil
    end
  end

  def self.opt_expand(opt) # モード名の拡張
    res = {}
    opt.each do |key, value|
      tmp = opt_name(key.to_s)
      eval("res[:#{tmp}] = '#{value}'")
    end
    res
  end

  def self.opt_name(str) # モード名返信
    list = {"f" => "config_file",
            "m" => "mode",
            "i" => "input_folders",
            "o" => "output_folder",
            "c" => "classification",
            "s" => "size",
            "d" => "date",
            "l" => "log",
            "mv"=> "move"
           }
    eval("list['#{str}']")  
  end

  def self.str_reduct(str,len,side="l") # 文字列の略化
    res = ""; len -= 2; n,m = 0,0;
    str.reverse.chars do |c| # マルチバイト処置
      if n < len
        n += c.bytesize != 1 ? 2 : 1
        m += 1
      end
    end

    if n == len + 1 # 各読み込みの長さと次のマルチバイト場合で換算
      res = "~"+str[str.length-m,m]
    elsif str.reverse.chars[m].bytesize != 1
      res = " ~"+str[str.length-m,m]
    else
      res = "~"+str[str.length-m-1,m+1]
    end
    
    res = res.ljust(len+2) if side == "l" && len > str.length # 左調整
    res = res.rjust(len+2) if side == "r" && len > str.length # 右調整
    res
  end

  def self.num_byte(num) # バイト数 -> 文字列
    units = ["  B"," KB"," MB"," GB"," TB"," PB"] # 
    u = 0
    num = num.to_i
    
    while num / 1000.0 >= 1.0
      u += 1
      num /= 1000
    end
    num.to_s + units[u]
  end

  def self.byte_num(byte) # 文字列 -> バイト数
    units = ["B","KB","MB","GB","TB","PB"] 
    /^([0-9]{1,3})([BKMGTP]{1,2})$/ =~ byte
      $1.to_i * (1000 ** units.index($2))
  end

  
  def self.str_ext(str1) # 拡張子抽出
    str1 = str1.gsub(/[^\/]*\//, "")
    str2 = str1.gsub(/[^\.]*\./, "")
    str2= "NONE" if str1 == str2
    str2
  end

  def self.date_folder(date,unit) # 日付 -> 時間単位
    list1 = ['YEAR','MONTH','DAY','HOUR','MINUTE']
    list2 = ['%Y','-%m','-%d','-%H',':%M']

    res = ""
    for n in 0..list1.index(unit)
      res = res + date.strftime(list2[n]) 
    end
    res
  end
end

