namespace :articles do
  desc "Remove articles that have been reported 6 or more times"
  task remove_heavily_reported: :environment do
    articles_to_remove = Article.where('reports_count >= ?', 6)

    puts "Found #{articles_to_remove.count} articles with 6+ reports"

    articles_to_remove.each do |article|
      puts "Removing article ID: #{article.id}, Title: '#{article.title}', Reports: #{article.reports_count}"
      article.destroy
    end

    puts "Task completed. Removed #{articles_to_remove.count} articles."
  end
end
