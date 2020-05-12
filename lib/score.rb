# coding: utf-8
class Score < Col # 移動先の変更を行う

  def self.main(list, opt)
    if opt[:c].include?("NONE") # NONE時はここで入力
      tmp = []; c = "" # 一時変数
      cputs ['input classification (1:EXT, 2:SIZE, 3:DATE (e.g. 1 -> 2)) stop: e ',3]
      tmp.push(Convert.num_class(c)) while (c = Col.cgets) != "e" 

      j = ["EXT", "SIZE", "DATE"] # 検証
      tmp.each do |sort|
        if sort.nil? # 候補外はエラー
          cerr "ERROR: input wrong sort!"
          exit 1
        end
      end
      opt[:c] = tmp
    end
    
    for sort in opt[:c] # 各ソートを実行
      cputs "START #{sort} SORT!"
      list = ext(list, opt)  if sort == "EXT"
      list = size(list, opt) if sort == "SIZE"
      list = date(list, opt) if sort == "DATE"
    end

    list
  end

  
  def self.ext(list, opt) # 拡張子
    res = []
    list.each do |file, path, info|
      res.push([file, path+"/"+Convert.str_ext(file), info])
    end
    res
  end


  def self.size(list, opt) # サイズ
    if opt[:s] == "NONE" # NONE時はここで入力
      cputs ["input interval size(e.g. 24KB 400MB)",3]
      opt[:s] = cgets
      
      units = ["B","KB","MB","GB","TB","PB"] 
      /^([0-9]{1,3})([BKMGTP]{1,2})$/ =~ opt[:s] # チェック
      if $1.nil? || $2.nil? || $1.to_i == 0
        cerr "ERROR: size #{opt[:s]} is wrong size!(number error)"
        exit 1
      end
      unless units.include?($2)
        cerr "ERROR: size #{opt[:s]} is wrong size!(byte error)"
        exit 1
      end
    end

    cputs "interval size is #{opt[:s]}"
    
    res = []

    byte_size = Convert.byte_num(opt[:s]) # 変換
    
    list.each do |file, path, info|
      folder_name = Convert.num_byte(info.size/byte_size*byte_size+byte_size).gsub(/\s/,"") # 候補
      res.push([file, path+"/"+folder_name, info]) # 更新
    end
    res
  end


  def self.date(list, opt) # 日付

    if opt[:d] == "NONE" # モード指定がない時, ここで選択する
      Col.cputs ["input date unit(1:YEAR, 2:MONTH, 3:DAY, 4:HOUR, 5:MINUTE)", 3]
      opt[:d] = Convert.num_date(Col.cgets)

      units = ['YEAR','MONTH','DAY','HOUR','MINUTE'] # チェック
      unless units.include?(opt[:d])
        cerr "ERROR: date units #{opt[:d]} is wrong date unit!(syntax error)"
        exit 1
      end      
    end

    cputs "date unit is #{opt[:d]}"

    res = [] # 初期化
    date = ""
    
    list.each do |file, path, info|
      res.push([file, path+"/"+Convert.date_folder(info.mtime,opt[:d]), info]) # 更新
    end
    res
  end


end
