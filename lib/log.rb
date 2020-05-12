# coding: utf-8

module Log # ログ出力するように変更( idea by matsumoto yukihiro )
  def self.output(output_file)
    defout = Object.new
    defout.instance_eval { @ofile = open(output_file, 'w') }
    class << defout
      def write(str)
        STDOUT.write(str)
        @ofile.write(str)
      end
    end
    $stdout = defout
  end
end

