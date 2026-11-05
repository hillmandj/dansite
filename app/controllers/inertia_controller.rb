# Base class for pages rendered with React via Inertia.
# See https://inertia-rails.dev/guide/shared-data for sharing data with every page.
class InertiaController < ApplicationController
  layout "inertia"
end
