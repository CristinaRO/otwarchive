class KudosSweeper < ActionController::Caching::Sweeper
  observe Kudo

  def after_create(kudo)
    if kudo.commentable_type == "Work"
      # delete the cache entry for the total kudos count on the work
      Rails.cache.delete "works/#{kudo.commentable_id}/kudos_count"
      # if guest kudo, delete the cache entry for guest_kudos_count to avoid guest kudos being stuck
      Rails.cache.delete "works/#{kudo.commentable_id}/guest_kudos_count" if kudo.pseud_id.nil?
    end

    # expire the cache for the kudos section in the view
    expire_fragment "#{kudo.commentable.cache_key}/kudos"
  end

  # ahaha this will never be called because there's no update action in the kudos controller *sob*
  # def after_update(kudo)
  #   return unless kudo.pseud_id_changed?

  #   if kudo.commentable_type == "Work"
  #     # if someone has deleted their account, delete the cache entry for guest_kudos_count
  #     Rails.cache.delete "works/#{kudo.commentable_id}/guest_kudos_count" if kudo.pseud_id.nil?
  #   end

  #   expire_fragment "#{kudo.commentable.cache_key}/kudos"
  # end
end
