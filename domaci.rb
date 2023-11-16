require 'google_drive'

class GoogleDriveTable
  include Enumerable

  attr_reader :moj_niz

  def initialize(spreadsheet_title, worksheet_title,start_red, start_kolona)
    @session = GoogleDrive::Session.from_config('config.json')
    @spreadsheet = @session.spreadsheet_by_title(spreadsheet_title)
    @worksheet = @spreadsheet.worksheets.first

    initialize_moj_niz(start_red, start_kolona)
    metode_za_kolone
  end

  def each
    return enum_for(:each) unless block_given?

    @worksheet.rows.each do |row|
      row.each do |cell|
        yield cell
      end
    end
  end
  def [](ime_kolone)
  indeks_kolone = @moj_niz[0].index(ime_kolone)
    

    @moj_niz.map { |row| row[indeks_kolone] }
  end

  def []=(ime_kolone, index, value)
  indeks_kolone = @moj_niz[0].index(ime_kolone)
    

    @moj_niz[index][indeks_kolone] = value
  end

  def ispisi_niz
    
    @moj_niz.each { |row| puts row.join("\t") }
  end

  def dohvati_red(index)
    red(index)
  end

  

  def metode_za_kolone  
    @moj_niz[0].each do |ime_kolone|
      next if ime_kolone.nil? 
  
      ime_metode = ime_kolone.downcase.tr(" ", "_")  
      define_singleton_method(ime_metode) do
        @moj_niz.map { |row| row[@moj_niz[0].index(ime_kolone)] }
      end
  
      define_singleton_method("#{ime_metode}.zbir") do
        zbir_kolone(ime_kolone)
      end
  
      define_singleton_method("#{ime_metode}.prosek") do
        prosek_kolone(ime_kolone)
      end
    end
  end
  

  def zbir_kolone(ime_kolone)
  indeks_kolone = @moj_niz[0].index(ime_kolone)
  vrednosti = @moj_niz.map { |row| row[indeks_kolone].to_f }
  vrednosti.sum
  end

  def prosek_kolone(ime_kolone)
    indeks_kolone = @moj_niz[0].index(ime_kolone)
    vrednosti = @moj_niz.map { |row| row[indeks_kolone].to_f }
    vrednosti.sum / vrednosti.size
  end
  def mapa_kolone(ime_kolone, &block)
    indeks_kolone = @moj_niz[0].index(ime_kolone)
    @moj_niz.map { |row| block.call(row[indeks_kolone]) }
  end

  def select_kolone(ime_kolone, &block)
    indeks_kolone = @moj_niz[0].index(ime_kolone)
    @moj_niz.select { |row| block.call(row[indeks_kolone]) }
  end

  def reduce_kolone(ime_kolone, initial, &block)
    indeks_kolone = @moj_niz[0].index(ime_kolone)
    @moj_niz.reduce(initial) { |acc, row| block.call(acc, row[indeks_kolone]) }
  end
  
  def red(index)
    @moj_niz[index - 1]
  end

  def initialize_moj_niz(start_red, start_kolona)
    redovi = @worksheet.num_rows
    kolone = @worksheet.num_cols
    @moj_niz = Array.new(redovi) { Array.new(kolone) }
  
    (start_red..redovi).each do |row|
      (start_kolona..kolone).each do |col|
        @moj_niz[row - start_red][col - start_kolona] = @worksheet[row, col]
      end
    end
  end
  
  
end
table = GoogleDriveTable.new('test', 'worksheet', 9, 4)

table.ispisi_niz
red = table.dohvati_red(3)
puts "prvi red #{red}"
table.each{|cell| puts cell}

column_data = table["Prva Kolona"]
puts "Prva Kolona: #{column_data}"

element = table["Prva Kolona"][2]
puts " #{element}"

table["Prva Kolona"][2] = 5

table.ispisi_niz
puts "Prva Kolona: #{table.prva_kolona()}"
puts "Druga Kolona: #{table.druga_kolona()}"
puts "Treca Kolona: #{table.treca_kolona()}"
prva_kolona_zbir = table.zbir_kolone("Prva Kolona")
puts "Zbir Prve Kolone: #{prva_kolona_zbir}"

prva_kolona_prosek = table.prosek_kolone("Prva Kolona")
puts "Prosek Prve Kolone: #{prva_kolona_prosek}"
mapped_values = table.mapa_kolone("Prva Kolona") { |cell| cell.to_i + 1 }
puts "Mapirane vrednosti: #{mapped_values}"

selected_rows = table.select_kolone("Prva Kolona") { |cell| cell.to_i > 2 }
puts "Selektovani redovi: #{selected_rows}"

sum = table.reduce_kolone("Prva Kolona", 0) { |acc, cell| acc + cell.to_i }
puts "Zbir #{sum}"
table.ispisi_niz

