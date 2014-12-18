require 'action_view'
require 'sprockets'

module Sprockets
  module Rails
    module Context
      if defined? ActionView::Helpers::AssetUrlHelper
        include ActionView::Helpers::AssetUrlHelper
        include ActionView::Helpers::AssetTagHelper
      else
        require 'sprockets/rails/legacy_asset_tag_helper'
        require 'sprockets/rails/legacy_asset_url_helper'
        include LegacyAssetTagHelper
        include LegacyAssetUrlHelper
      end

      def self.included(klass)
        klass.class_eval do
          class_attribute :config, :assets_prefix, :digest_assets
        end
      end

      def compute_asset_path(path, options = {})
        begin
          asset_uri = locate(path)
        rescue FileNotFound
          # TODO: eh, we should be able to use a form of locate that returns
          # nil instead of raising an exception.
        end

        if asset_uri
          asset = link_asset(path)
          digest_path = asset.digest_path
          path = digest_path if digest_assets
          File.join(assets_prefix || "/", path)
        else
          super
        end
      end
    end
  end
end
