# coding: utf-8
class InOut < Col
  attr_accessor :list # ファイルリスト共有のため操作を受け付ける
  
  def initialize(params)
    @list = Array.new
    pwd = Dir.pwd # 初期ディレクトリ
    cputs "load input files."
    input(pwd, params[:o], params[:i])
    Dir.chdir(pwd) # 初期ディレクトリ
  end

  def input(pwd, out, folders) # 回帰的なファイル捜索
    for folder in folders
      Dir.chdir(pwd) # 現在立っている場所
      Dir.chdir(folder) # 指名された場所に移動する
      tpwd = Dir.pwd

      for file in Dir.glob("*") # 移動先でファイル捜索
        break if file.nil?
        path = tpwd + "/" + file # 捜査ファイルのパス確保
        if File.directory?(path) # ディレクトリならその中を再帰捜索
          input(tpwd, out, [path])
        elsif File.file?(path) # ファイルならリスト挿入
          @list.push([path,out,File.stat(path)]) # [ファイルの初期パス, 初期移動先パス, 情報]
        end
      end
      
    end
    
  end

  def output(opt)
    cputs "output files."
    
    if opt[:mv] # move判定
      cputs "file mode :move"
    else
      cputs "file mode :copy"
    end
    
    @list.each do |f_in, f_out, info|
      unless File.directory?(f_out) # フォルダがない時, 作成
        FileUtils.mkdir_p(f_out)
      end
      if opt[:mv] # 実行
        FileUtils.mv(f_in,f_out)
      else
        FileUtils.cp(f_in,f_out)
      end
      cputs [[f_in],[" -> ",3],[f_out]] # 結果表示
    end

    cputs ["file sorting done!", 7]
  end
  
end
