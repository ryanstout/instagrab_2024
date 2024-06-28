def wait_for_selector(page, selector, wait_time)
  start_time = Time.now
  while Time.now - start_time < wait_time
    element = page.at_css(selector)
    return element if element
    sleep 0.1
  end

  nil
end

def wait_for_xpath(path, xpath_selector, wait_time)
  start_time = Time.now
  while Time.now - start_time < wait_time
    element = path.at_xpath(xpath_selector)
    return element if element
    sleep 0.1
  end

  nil
end

def realistic_type(page, element, text)
  element.focus
  text.each_char do |char|
    element.type(char)
    sleep 0.1 + rand
  end
end

def largest_image_src(page)
  js_code = <<~JS
    (function() {
      function getLargestVisibleImage() {
          // if there is a video element, reutrn null
          var videos = document.querySelectorAll('article[role="presentation"] video');

          var images = document.querySelectorAll('article[role="presentation"] img');
          images = Array.from(images);

          // add videos to images
          videos.forEach(video => {
              images.push(video);
          });

          let largestImage = null;
          let largestArea = 0;

          images.forEach(img => {
              const rect = img.getBoundingClientRect();
              const isVisible = rect.width > 0 && rect.height > 0 && rect.top >= 0 && rect.left >= 0 &&
                                rect.bottom <= (window.innerHeight || document.documentElement.clientHeight) &&
                                rect.right <= (window.innerWidth || document.documentElement.clientWidth);

              if (isVisible) {
                  const area = rect.width * rect.height;
                  if (area > largestArea) {
                      largestArea = area;
                      largestImage = img;
                  }
              }
          });

          // if the largest image is a video, return null
          if (largestImage.tagName === 'VIDEO') {
              return null;
          }

          return largestImage ? largestImage.src : null;
      }
      return getLargestVisibleImage();
    })();
  JS

  page.evaluate(js_code)
end

# def save_image_from_selector(page, image_url, path)
#   script = <<~JS
#     (function() {
#     var canvas = document.createElement('canvas');
#     var ctx = canvas.getContext('2d');
#     var img = document.querySelector(#{selector.inspect});
#     canvas.width = img.naturalWidth;
#     canvas.height = img.naturalHeight;
#     ctx.drawImage(img, 0, 0);
#     return canvas.toDataURL('image/jpeg').replace(/^data:image\\/(jpeg|jpg);base64,/, '');
#     })();
#   JS

#   image_data_base64 = page.evaluate(script)

#   # script = <<~JS
#   #   fetch("#{image_url}")
#   #   .then(response => {
#   #     if (!response.ok) {
#   #       throw new Error('Network response was not ok');
#   #     }
#   #     return response.blob();
#   #   })
#   #   .then(blob => new Promise((resolve, reject) => {
#   #     const reader = new FileReader();
#   #     reader.onloadend = () => resolve(reader.result);
#   #     reader.onerror = error => reject(error);
#   #     reader.readAsDataURL(blob);
#   #   }))
#   #   .catch(error => console.error('Error fetching or processing image:', error))
#   # JS

#   # image_data_base64 = page.evaluate_async(script, 10)

#   File.open(path, "wb") do |f|
#     f.write(Base64.decode64(image_data_base64))
#   end
# end

def download_image_url_in_new_tab(browser, image_url)
  download_page = nil
  begin
    download_page = browser.create_page

    sleep 1 + rand

    download_page.goto(image_url)
    wait_for_page_fully_loaded(download_page)

    sleep 2 + rand

    return find_image_in_traffic_history(download_page, image_url)
  ensure
    download_page.close if download_page
  end
end

def find_image_in_traffic_history(page, image_url)
  # Find the network request that downloaded the image
  image_requests = page.network.traffic.select do |request|
    request.url == image_url
  end

  if image_requests.empty?
    return nil
  else
    # Grab the largest image request
    image_request = image_requests.select { |request| request.response.body rescue false }.sort_by { |request| request.response.body.size }.last

    if !image_request || image_request.response.body.size == 0
      return nil
    else
      return image_request.response.body
    end
  end
end

def wait_for_page_fully_loaded(page, timeout = 3 * 60)
  # puts "Wait for idle"
  # page.network.wait_for_idle!(timeout: 3 * 60)
  # puts "Page loaded"

  # Check readyState in a loop
  puts "waiting for idle"
  start_time = Time.now
  while Time.now - start_time < timeout
    ready_state = page.evaluate("document.readyState")
    if ready_state == "complete"
      puts "Complete"
      return
    end
    sleep 0.3
  end

  puts "Didn't complete"
end

def set_field_with_arrow(field, value)
  field.focus

  sleep 1 + rand

  field.click
  sleep 1 + rand

  field.type(value)

  sleep 2 + rand(3)
end
