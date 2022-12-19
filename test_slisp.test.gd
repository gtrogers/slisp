extends GutTest

var Slisp = ResourceLoader.load("res://slisp.gd")

func test_put():
	var s = Slisp.new("Hello <put what> what a nice <put thing><put punc>")
	assert_eq(
		s.render({'what': 'world', 'thing': 'day', 'punc': '!'}),
		"Hello world what a nice day!"
	)
	
	var s2 = Slisp.new("<put \"foo\" \"bar\">")
	assert_eq(
		s2.render({}),
		"foobar"
	)
	
	var s3 = Slisp.new('<put "foo" bar "zap">')
	assert_eq(
		s3.render({'bar': 'pow'}),
		"foopowzap"
	)

func test_when():
	var s = Slisp.new("Ya<when super_pirate \"aaa\">r")
	assert_eq(
		s.render({'super_pirate': true}),
		"Yaaaar"
	)
	
	assert_eq(
		s.render({'super_priate': false}),
		"Yar"
	)

func test_when_with_pred():
	var s = Slisp.new('<when <eq foo "bar"> "zap">')
	
	assert_eq(
		s.render({'foo': 'bar'}),
		"zap"
	)

func test_if():
	var s = Slisp.new('<if foo "bar" "zap">')
	
	assert_eq(s.render({'foo': true}), "bar")
	assert_eq(s.render({'foo': false}), "zap")

func test_nesting():
	var s = Slisp.new("<if foo <str a> <str b>>")
	
	assert_eq(s.render({'foo': true, 'a': '1', 'b': '2'}), '1')
