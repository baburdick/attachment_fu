require 'image_science'
module Technoweenie # :nodoc:
  module AttachmentFu # :nodoc:
    module Processors
      module ImageScienceProcessor
        def self.included(base)
          base.send :extend, ClassMethods
          base.alias_method_chain :process_attachment, :processing
        end

        module ClassMethods
          # Yields a block containing an Image Science image for the given binary data.
          def with_image(file, &block)
            ::ImageScience.with_image file, &block
          end
        end

        protected
          def process_attachment_with_processing
            return unless process_attachment_without_processing && image?
            with_image do |img|
              self.width  = img.width  if respond_to?(:width)
              self.height = img.height if respond_to?(:height)
              resize_image_or_thumbnail! img
            end
          end

          # Performs the actual resizing operation for a thumbnail
          def resize_image(img, size, model)
            # create a dummy temp file to write to
            # ImageScience doesn't handle all gifs properly, so it converts them to
            # pngs for thumbnails.  It has something to do with trying to save gifs
            # with a larger palette than 256 colors, which is all the gif format
            # supports.
            filename.sub! /gif$/i, 'png'
            content_type.sub!(/gif$/, 'png')
            temp_paths.unshift write_to_temp_file(filename)
            grab_dimensions = lambda do |img|
              self.width  = img.width  if respond_to?(:width)
              self.height = img.height if respond_to?(:height)

              # We don't check for quality being a 0-100 value as we also allow FreeImage JPEG_xxx constants.
              quality = content_type[/jpe?g/i] && get_jpeg_quality(false)
              # Traditional ImageScience has a 1-arg save method, tdd-image_science has 1 mandatory + 1 optional
              if quality && img.method(:save).arity == -2
                img.save self.temp_path, quality
              else
                img.save self.temp_path
              end
              self.size = File.size(self.temp_path)
              callback_with_args :after_resize, img
            end

            size = size.first if size.is_a?(Array) && size.length == 1
            if size.is_a?(Fixnum) || (size.is_a?(Array) && size.first.is_a?(Fixnum))
              if size.is_a?(Fixnum)
                img.thumbnail(size, &grab_dimensions)
              else
                img.resize(size[0], size[1], 0, &grab_dimensions)
              end
            else
              new_size = [img.width, img.height] / size.to_s
              if size.ends_with? "c"
                aspect = new_size[0].to_f / new_size[1].to_f
                ih, iw = img.height, img.width
                width, height = (ih * aspect), (iw / aspect)

                width = [iw, width].min.to_i
                height = [ih, height].min.to_i

                unless (model.nil? or model.x1.nil? or model.x2.nil? or model.y2.nil? or model.y1.nil? or model.big_width.nil? or model.big_height.nil? or model.height.nil? or model.width.nil?)
                  left = (model.x1.to_f / model.big_width) * model.width
                  right = (model.x2.to_f / model.big_width) * model.width
                  top = (model.y2.to_f / model.big_height) * model.height
                  bottom = (model.y1.to_f / model.big_height) * model.height
                else
                  left = (iw-width)/2
                  top = (ih-height)/2
                  right = (iw+width)/2
                  bottom = (ih+height)/2
                end

                #( (iw-w)/2, (ih-h)/2, (iw+w)/2, (ih+h)/2) { |crop| crop.resize(new_size[0], new_size[1], &grab_dimensions ) }
                img.with_crop(left.to_i, top.to_i, right.to_i, bottom.to_i) { |crop| crop.thumbnail(new_size, false, &grab_dimensions) }
              elsif size.ends_with? "g"
                aspect = new_size[0].to_f / new_size[1].to_f
                ih, iw = img.height, img.width
                w, h = (ih * aspect), (iw / aspect)
                w = [iw, w].min.to_i
                h = [ih, h].min.to_i

                unless (model.nil? or model.x1.nil? or model.x2.nil? or model.y2.nil? or model.y1.nil? or model.big_width.nil? or model.big_height.nil? or model.height.nil? or model.width.nil?)
                  left = (model.x1.to_f / model.big_width) * model.width
                  right = (model.x2.to_f / model.big_width) * model.width
                  top = (model.y2.to_f / model.big_height) * model.height
                  bottom = (model.y1.to_f / model.big_height) * model.height
                else
                  left = (iw-w)/2
                  top = (ih-h)/2
                  right = (iw+w)/2
                  bottom = (ih+h)/2
                end

                img.with_crop(left.to_i, top.to_i, right.to_i, bottom.to_i) { |crop| crop.thumbnail(new_size, true, &grab_dimensions) }
              elsif size.ends_with? "!"
                aspect = new_size[0].to_f / new_size[1].to_f
                ih, iw = img.height, img.width
                w, h = (ih * aspect), (iw / aspect)
                w = [iw, w].min.to_i
                h = [ih, h].min.to_i
                img.with_crop((iw-w)/2, (ih-h)/2, (iw+w)/2, (ih+h)/2) { |crop|
                  crop.resize(new_size[0], new_size[1], 0, &grab_dimensions)
                }
              else
                img.thumbnail(new_size, false, &grab_dimensions)
              end
            end
          end
      end
    end
  end
end