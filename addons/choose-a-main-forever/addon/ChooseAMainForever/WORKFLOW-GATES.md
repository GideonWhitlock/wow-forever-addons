# Mandatory workflow gates

These gates apply to every maintenance, testing, packaging and publication task for **Choose a Main: Forever**.

## Completed-state gate

1. Carry the requested task through its final **Save**, **Submit** or **Publish** action, as authorised.
2. Reload or reopen the destination and verify the real persisted state rather than trusting an editor preview, toast or local form state.
3. Record the resulting version, URL, identifier, checksum or visible saved state as applicable.
4. Close every temporary browser tab, editor tab, upload dialog, file picker and auxiliary application used for the task.
5. Do not report completion while an unsaved form, unsubmitted review, pending upload or ambiguous success screen remains.

Publication still requires explicit owner approval. This gate requires completing an authorised workflow; it does not grant permission to publish.

## CurseForge image gate

Every CurseForge logo, thumbnail, gallery image and screenshot must pass all of the following:

1. Prepare the source with generous safe margins around the important subject.
2. Deliberately centre the subject and expand or reposition the crop; never accept the automatic crop without inspection.
3. Inspect the small author-editor preview at approximately player-visible thumbnail size.
4. Save the image or crop.
5. Reload the editor or project page and verify the persisted crop.
6. Inspect the actual project-list or public thumbnail at player-visible size, not only the large source image.
7. Treat any clipped, off-centre, corner-only or unintended black-background result as failed.
8. Correct, save, reload and inspect again until the public thumbnail passes.
9. Close the image editor, upload dialog and temporary tabs only after verification.

No CurseForge image is complete merely because the upload succeeded.
