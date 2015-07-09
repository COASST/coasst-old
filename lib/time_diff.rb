def time_diff_in_minutes (start, finish)
	diff_seconds(start, finish) / 60
end

def time_diff_in_days (start, finish)
	diff_seconds(start, finish) / (60 * 60 * 24)
end

def diff_seconds(start, finish)
	(finish - start).round
end

