;;; agent-shell-completion-tests.el --- Tests for agent-shell completion -*- lexical-binding: t; -*-

(require 'ert)
(require 'map)
(require 'agent-shell-completion)

;;; Code:

(ert-deftest agent-shell--completion-bounds-ignores-path-separators-test ()
  "Test `/` in file paths does not trigger command completion."
  (let ((command-chars "[:alnum:]_-")
        (path-chars "[:alnum:]/_.-"))
    (with-temp-buffer
      (insert "@path/abc")
      (goto-char (point-max))
      (should-not (agent-shell--completion-bounds command-chars ?/))
      (let ((bounds (agent-shell--completion-bounds path-chars ?@)))
        (should bounds)
        (should (equal (map-elt bounds :start) 2))
        (should (equal (map-elt bounds :end) 10)))))

  (with-temp-buffer
    (insert " /help")
    (goto-char (point-max))
    (let ((bounds (agent-shell--completion-bounds "[:alnum:]_-" ?/)))
      (should bounds)
      (should (equal (map-elt bounds :start) 3))
      (should (equal (map-elt bounds :end) 7)))))

(ert-deftest agent-shell--completion-retrigger-p-in-file-context-test ()
  "Point inside an active @ context re-triggers (returns ?@)."
  (with-temp-buffer
    (insert " @rea")
    (goto-char (point-max))
    (should (equal (agent-shell--completion-retrigger-p) ?@))))

(ert-deftest agent-shell--completion-retrigger-p-plain-word-test ()
  "Ordinary words (no @ or / trigger) never re-trigger completion.
This guards against surfacing comint's filesystem completion for words
like `agent-shell'."
  (with-temp-buffer
    (insert "agent-shell")
    (goto-char (point-max))
    (should-not (agent-shell--completion-retrigger-p))))

(ert-deftest agent-shell--completion-retrigger-p-after-trigger-deleted-test ()
  "Once the @ trigger is gone, re-triggering stops."
  (with-temp-buffer
    (insert " rea")
    (goto-char (point-max))
    (should-not (agent-shell--completion-retrigger-p))))

(provide 'agent-shell-completion-tests)
;;; agent-shell-completion-tests.el ends here
