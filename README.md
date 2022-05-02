Numa: non unified mapper, A)

```ruby
require 'numa'

Numa.new do

  get do
    res.write 'hello'
  end

  on '/:any' do
    res.redirect '/'
  end


end
```
