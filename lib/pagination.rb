#!/usr/bin/env ruby
# Id$ nonnax 2022-05-02 21:05:34 +0800
def paginate(db, from: 1)
  # paginate data store
  # validates and adjusts value of `from`
  return [from, []] if db.size.zero?

  from = [from.to_i, 1].max
  from = [from, db.size].min

  pages = [from]

  [0, 1, 2].inject(pages){|acc, i|
    acc << [from-i, 1].max
    acc << [from+i, db.size].min
  }

  pages = [1, pages, db.size].flatten

  [from, pages.uniq.sort.select(&:positive?)]
end
