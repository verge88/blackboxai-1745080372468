package com.example.notesapp

import android.os.Bundle
import android.text.InputType
import android.view.LayoutInflater
import android.view.ViewGroup
import android.widget.EditText
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.android.material.snackbar.Snackbar

class MainActivity : AppCompatActivity() {

    private val notes = mutableListOf<String>()
    private lateinit var notesRecyclerView: RecyclerView
    private lateinit var adapter: NotesAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        notesRecyclerView = findViewById(R.id.notesRecyclerView)
        adapter = NotesAdapter(notes) { position -> deleteNote(position) }
        notesRecyclerView.adapter = adapter

        val addNoteButton: FloatingActionButton = findViewById(R.id.addNoteButton)
        addNoteButton.setOnClickListener {
            showAddNoteDialog()
        }
    }

    private fun showAddNoteDialog() {
        val input = EditText(this)
        input.inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_MULTI_LINE

        AlertDialog.Builder(this)
            .setTitle("Add Note")
            .setView(input)
            .setPositiveButton("Add") { dialog, _ ->
                val noteText = input.text.toString().trim()
                if (noteText.isNotEmpty()) {
                    addNote(noteText)
                } else {
                    Snackbar.make(notesRecyclerView, "Note cannot be empty", Snackbar.LENGTH_SHORT).show()
                }
                dialog.dismiss()
            }
            .setNegativeButton("Cancel") { dialog, _ -> dialog.cancel() }
            .show()
    }

    private fun addNote(note: String) {
        notes.add(0, note)
        adapter.notifyItemInserted(0)
        notesRecyclerView.scrollToPosition(0)
    }

    private fun deleteNote(position: Int) {
        val removedNote = notes[position]
        notes.removeAt(position)
        adapter.notifyItemRemoved(position)
        Snackbar.make(notesRecyclerView, "Note deleted", Snackbar.LENGTH_LONG)
            .setAction("Undo") {
                notes.add(position, removedNote)
                adapter.notifyItemInserted(position)
            }
            .show()
    }

    class NotesAdapter(
        private val notes: List<String>,
        private val onDeleteClick: (Int) -> Unit
    ) : RecyclerView.Adapter<NotesAdapter.NoteViewHolder>() {

        inner class NoteViewHolder(val view: android.view.View) : RecyclerView.ViewHolder(view) {
            val noteTextView: android.widget.TextView = view.findViewById(R.id.noteTextView)

            init {
                view.setOnLongClickListener {
                    onDeleteClick(adapterPosition)
                    true
                }
            }
        }

        override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): NoteViewHolder {
            val view = LayoutInflater.from(parent.context)
                .inflate(R.layout.item_note, parent, false)
            return NoteViewHolder(view)
        }

        override fun onBindViewHolder(holder: NoteViewHolder, position: Int) {
            holder.noteTextView.text = notes[position]
        }

        override fun getItemCount(): Int = notes.size
    }
}
