import subprocess, sys, tempfile, os, unittest
def run(*a):
    return subprocess.run([sys.executable, 'wordfreq.py', *a], capture_output=True, text=True)
class Hidden(unittest.TestCase):
    def setUp(self):
        fd, self.p = tempfile.mkstemp(suffix='.txt'); os.close(fd)
        open(self.p, 'w', encoding='utf-8').write('The cat. the DOG, the cat! bird')
    def tearDown(self): os.remove(self.p)
    def test_top(self):
        r = run(self.p, '--top', '2')
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(r.stdout.split('\n')[:2], ['the 3', 'cat 2'])
    def test_tie_order(self):
        lines = run(self.p).stdout.strip().split('\n')
        self.assertEqual(lines[2:], ['bird 1', 'dog 1'])
    def test_missing(self):
        self.assertEqual(run('nope-does-not-exist.txt').returncode, 2)
