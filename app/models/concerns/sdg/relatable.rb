module SDG::Relatable
  extend ActiveSupport::Concern

  included do
    has_many :sdg_relations, as: :relatable, dependent: :destroy, class_name: "SDG::Relation"

    %w[SDG::Goal SDG::Target SDG::LocalTarget].each do |sdg_type|
      has_many sdg_type.constantize.table_name.to_sym,
               through: :sdg_relations,
               source: :related_sdg,
               source_type: sdg_type
    end
  end

  class_methods do
    def by_goal(code)
      return all if code.blank?

      joins(:sdg_goals).merge(SDG::Goal.where(code: code))
    end
  end

  def related_sdgs
    sdg_relations.map(&:related_sdg)
  end

  def sdg_goal_list
    sdg_goals.map(&:code).join(", ")
  end

  def sdg_target_list
    sdg_targets.map(&:code).join(", ")
  end

  def sdg_target_list=(codes)
    targets = codes.tr(" ", "").split(",").map { |code| SDG::Target[code] }

    transaction do
      self.sdg_targets = targets
      self.sdg_goals = targets.map(&:goal).uniq
    end
  end
end
