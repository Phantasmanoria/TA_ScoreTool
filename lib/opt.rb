# coding: utf-8
require 'optparse'
require 'yaml'

# 初期情報を取得
class Opt < Col
  
  def initialize
    cputs "load options."
    param = get_opt
    cputs "load config file."
    yaml = yaml_load(param[:f])
    cputs "check options."
    mix_check(param,yaml)
  end

  
  def param # paramの取得(外部取得を防ぐため)
    @params
  end
  
  private
  def get_opt # オプションから情報を入手
    opt = OptionParser.new
    params = {:f => "config.yml"} # 初期値

    begin
      opt.on('-p [NUMBER]',/^[1-3]$/,
             'prog lecture number (1,2,3)(default:2)')  {|v| params[:p] = v}
      opt.on('-t [NUMBER]',/^[0-9]+[A-B]*\_[0-9]+$/,
             'lecture task number (e.g. 1_2)(default:NONE)')  {|v| params[:t] = v}
      opt.on('-c [FILE]',
             'config file (default:config.yml)')  {|v| params[:c] = v}
      opt.on('-s [NUMBER, NUMBER, ..]', Array,
             'student numbers (default:NONE)')  {|v| params[:s] = v}
      opt.on('-l', 'log output(default:false)')  {|v| params[:l] = v}
      opt.on('-m [MODE]', ['SCORE',  'CONF', 'NONE'],
             'mode (SCORE|CONF|NONE) (default:NONE)')  {|v| params[:m] = v}
      opt.on('--init', 'reset all settings (default:off)')  {|v| params[:init] = v}
      opt.parse!(ARGV)
    rescue => e # エラー処理
      cerr "ERROR: #{e}.\nSee option!\n#{opt}"
      exit
    end

    init unless params[:init].nil? # initフラグがあれば初期化実行

    params
  end

  
  def init # コンフィグ初期化
    cputs "[[init mode]]"
    unless Dir.exist?("prog1") # prog1ファイル
      cputs "make prog1 folder."
      Dir.mkdir("prog1")
    end
    unless Dir.exist?("prog2") # prog2ファイル
      cputs "make prog2 folder."
      Dir.mkdir("prog2")
    end
    unless Dir.exist?("prog3") # prog3ファイル
      cputs "make prog3 folder."
      Dir.mkdir("prog3")
    end
    unless Dir.exist?("log") # logファイル
      cputs "make log folder."
      Dir.mkdir("log")
    end
    FileUtils.rm("config.yml") if File.exist?("config.yml")
    mkconfig # configファイル作り直し
    cputs "reset all settings! exit process..."
    exit 0 # 終了
  end

  
  def yaml_load(conf) # yaml読み込み
    conft = conf
    until File.exist?(conf) 
      cerr "ERROR: config file #{conf} is not exist!"
      if conft != "config.yml"  # -fのコンフィグファイルが存在しないと標準ファイルに変更
        cputs ["change config file as config.yml from #{conf}", 5]
        conft = "#{conf} -> config.yml"
        conf = "config.yml"
        cputs "reload config file."
      else # 標準ファイルがなければ作成
        cerr "ERROR: config_file config.yml is not exist!"
        mkconfig
      end      
    end

    yaml = YAML.load_file(conf) until yaml # 読み込み
    res = {}
    # 情報読み取り
    res[:p] = yaml["prog_number"] unless yaml["prog_number"].nil?
    res[:t] = yaml["task_number"] unless yaml["task_number"].nil?
    res[:m] = yaml["mode"] unless yaml["mode"].nil?
    res[:s] = yaml["student_numbers"] unless yaml["student_numbers"].nil?
    res[:l] = yaml["log"] == "true" ? true : false

    res[:f] = conft # conf情報上書き
    
    res
  end


  def mkconfig # configファイル作成
    cputs "making config_file ..."
    data = {
      "ta_number" => "NONE",
      "ta_pass" => "NONE", 
      "prog_number" => Time.new.year,
      "prog_year" => "NONE",
      "task_number" => "NONE",
      "mode" => "NONE",
      "student_numbers" => ["NONE"],
      "log" => "false",
      "compile_gcc" => "gcc",
      "compile_java" => "javac -encoding utf -8",
      "compile_gplus" => "g++",
    }
    YAML.dump(data, File.open("config.yml", "w"))
  end

  
  def mix_check(param, yaml) # オプションの統合と有効判定

    optdefault = {:c=>"config.yml", # 最初のopt設定
                  :p=>"2",
                  :t=>"NONE",
                  :m=>"NONE",
                  :s=>["NONE"],
                  :l=>false,
                 }
    
    conf = yaml[:f] # fオプションのみ救済
    res = (optdefault.merge(yaml)).merge(param) # opt初期 < yaml設定 < opt指定で優先で上書き
    res[:f] = conf # fオプションの適応


    err = [] # エラー格納
=begin
    for f_name in res[:i] 
      unless Dir.exist?(f_name) # -iでのフォルダが存在しないとエラー
        cerr "ERROR: input_folder #{f_name} is not exist!"
        err.push(Convert.opt_name("i"))
      end
      if File.expand_path(f_name) == File.expand_path(res[:o]) # -iと-oが同じならエラー
        cerr "ERROR: input_folder and output_folder is same folder!"
        err.push(Convert.opt_name("i"))
        err.push(Convert.opt_name("o"))
      end
    end

    unless Dir.exist?(res[:o]) # -oでのフォルダが存在しないとエラー
      cerr "ERROR: output_folder #{f_name} is not exist!"
      err.push(Convert.opt_name("o"))
    else
      res[:o] = File.expand_path(res[:o])
    end

    if res[:m].nil? # -mでのモードが該当しないとエラー(optperseによりnilになる)
      cerr "ERROR: invalid argument -m!(syntax error)"
      err.push(Convert.opt_name("m"))
    end

    if res[:d].nil? # -dでのモードが該当しないとエラー(optperseによりnilになる)
      cerr "ERROR: invalid argument -d!(syntax error)"
      err.push(Convert.opt_name("d"))
    end

    unless res[:c] != ["NONE"] # -cがNONEじゃない時は指定時のみ
      j = ["EXT", "SIZE", "DATE", "NONE"]
      res[:c].each do |sort|
        if not j.include?(sort) # 候補外はエラー
          cerr "ERROR: invalid argument -c!(syntax error)"
          err.push(Convert.opt_name("c"))
        elsif sort == "NONE" # NONEが含まれていたらNONEに強制変更
          res[:c] = ["NONE"]
        end
      end
    end

    if res[:s].nil? # -mでのモードが該当しないとエラー
        cerr "ERROR: invalid argument -s!(syntax error)"
        err.push(Convert.opt_name("s"))      
    elsif res[:s] != "NONE"
      byte = ["B","KB","MB","GB","TB", "PB"]
      /^([0-9]{1,3})([BKMGTP]{1,2})$/ =~ res[:s]
      if $1.nil? || $2.nil? || $1.to_i == 0
        cerr "ERROR: invalid argument -s!(number error)"
        err.push(Convert.opt_name("s"))
      end
      unless byte.include?($2)
        cerr "ERROR: invalid argument -s!(byte error)"
        err.push(Convert.opt_name("s"))
      end
    end

    if res[:l] # -lがついている時, logファイルがない時は作成
      unless Dir.exist?("log") # logファイル
        cputs "make log folder."
        Dir.mkdir("log")
      end
    end
    
    Display.conf(res,err) if err.length != 0 # エラー内容表示
=end    
    @params = res
  end

    
end

