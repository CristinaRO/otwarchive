class ToysController < ApplicationController
  # Enigel's experimental toy; don't refresh too much!
  def brainhurter
    if current_user.is_a?(User)
      @crtUserFandoms = ( (current_user.tags.uniq.select {|t| t.is_a?(Fandom) && t.canonical?}) + (current_user.tags.uniq.select {|t| t.is_a?(Fandom) && t.merger}.collect(&:merger)) ).uniq
      @crtUserCharas  = ( (current_user.tags.uniq.select {|t| t.is_a?(Character) && t.canonical?}) + (current_user.tags.uniq.select {|t| t.is_a?(Character) && t.merger}.collect(&:merger)) ).uniq
      
      if !params[:level].blank? && params[:level].to_s.downcase == "kamikaze"
        @crtUserSum = (@crtUserFandoms.collect {|f| f.characters.canonical} + @crtUserCharas).flatten.uniq
        pool = Array.new(@crtUserSum)
      else
        pool = Array.new(@crtUserCharas)
      end
      
      if @crtUserFandoms.size < 2 || pool.size < 2
        flash[:error] = "Sorry, you need to have written in at least two different fandoms, at least two different characters!"
      else
        if !params[:pairings_count].blank? && ["5","10","15","20"].include?(params[:pairings_count])
          @pairings = []
          # while !pool.empty? && !(pool.collect {|c| c.fandoms}.flatten.uniq.sort.to_s == pool[0].fandoms.uniq.sort.to_s) # this is a bad, bad thing to do!
          params[:pairings_count].to_i.times do
            character = pool[rand(pool.size)]
            pool.delete(character)
            mate = pool[rand(pool.size)]
            infinite_loop = 0
            until (mate.fandoms & character.fandoms).empty? || infinite_loop > 100
              mate = pool[rand(pool.size)]
              infinite_loop += 1
            end
            pairing = {:top => character, :bottom => mate}
            @pairings << pairing
            pool.delete(mate)
            break if pool.size < 2 || pool.collect(&:fandoms).flatten.uniq.size < 2
          end
          @pairings = @pairings.flatten unless @pairings.blank?
        end
      end
    else
      flash[:error] = "Sorry, this functionality is currently only available to registered users!"
    end
  end

end