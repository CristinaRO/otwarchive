module TagTypeHelper

  # Determines the appropriate CSS class given the tag class name e.g. "Archive"
  #
  # Examples
  #
  #   tag_type_class("ArchiveWarning")
  #   # => "warning"
  def tag_type_class(tag_type)

    tag_type = tag_type.classify
    case tag_type
    when "AdditionalTag"
      "freeform"
    when "ArchiveWarning"
      "warning"
    else
      tag_type.downcase
    end
  end

  # Determines the Tag Type labels e.g "Warnings", "Categories", "Fandoms"
  #
  # Examples
  #
  #   tag_type_label_name("archive_warning")
  #   # => "Warnings"
  def tag_type_label_name(tag_type)
    if tag_type.underscore == 'archive_warning'
      ArchiveWarning.label_name
    else
      tag_type.humanize.titleize.pluralize
    end
  end
end
