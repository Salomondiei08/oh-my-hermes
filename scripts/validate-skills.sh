#!/usr/bin/env bash
# Parse YAML safely and check required sections and local Markdown file links.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command -v ruby >/dev/null || { echo '[ERROR] Ruby with standard-library YAML is required for skill validation.'; exit 1; }
ruby --disable-gems -ryaml -ruri - "$SCRIPT_DIR/../skills" <<'RUBY'
root = File.expand_path(ARGV.fetch(0))
pattern = File.directory?(File.join(root, 'oh-my-hermes')) ? ['oh-my-hermes', '*', 'SKILL.md'] : ['*.md']
files = Dir[File.join(root, *pattern)].sort
abort '[ERROR] No Oh My Hermes skills found.' if files.empty?
failures = []
files.each do |file|
  text = File.read(file)
  label = File.basename(file)
  begin
    frontmatter = text.match(/\A---\r?\n(.*?)\r?\n---(?:\r?\n|\z)/m)
    raise 'missing delimited YAML frontmatter' unless frontmatter
    data = YAML.safe_load(frontmatter[1])
    raise 'frontmatter must be a mapping' unless data.is_a?(Hash)
    %w[name description version tags].each do |key|
      value = data[key]
      raise "missing or invalid #{key}" unless key == 'tags' ? value.is_a?(Array) && !value.empty? && value.all? { |tag| tag.is_a?(String) } : value.is_a?(String) && !value.strip.empty?
    end
    expected_name = File.basename(file) == 'SKILL.md' ? File.basename(File.dirname(file)) : File.basename(file, '.md')
    raise 'name must match skill path' unless data['name'] == expected_name
    %w[When\ to\ Use Prerequisites Procedure Pitfalls Verification].each do |section|
      raise "missing ## #{section}" unless text.match?(/^## #{Regexp.escape(section)}\s*$/)
    end
    raise 'possible hardcoded secret; review file' if text.match?(/(?:api_key|token|password|secret)\s*=\s*[a-z0-9_-]{20,}/i)
    # shortcut: check inline local file links only; anchors, remote URLs and reference links require separate review.
    text.scan(/\]\(([^\s)]+)(?:\s+"[^"]*")?\)/).flatten.each do |target|
      next if target.start_with?('#', '/') || target.match?(/\A[a-z][a-z0-9+.-]*:/i)
      path = URI::DEFAULT_PARSER.unescape(target.split(/[?#]/, 2).first)
      raise "broken local link: #{target}" unless File.exist?(File.expand_path(path, File.dirname(file)))
    end
    puts "[OK] #{label}"
  rescue StandardError => error
    failures << "[FAIL] #{label}: #{error.message}"
  end
end
puts failures
puts "Skills: #{files.length}   Failed: #{failures.length}"
puts 'Link checks cover inline local files; remote URLs, anchors and reference-style links are not checked.'
exit(failures.empty? ? 0 : 1)
RUBY
