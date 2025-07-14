import { Note } from '@/types/note';
import { NoteCard } from './NoteCard';

interface NotesGridProps {
  notes: Note[];
  onEditNote: (note: Note) => void;
  onDeleteNote: (id: string) => void;
}

export function NotesGrid({ notes, onEditNote, onDeleteNote }: NotesGridProps) {
  if (notes.length === 0) {
    return (
      <div className="flex items-center justify-center h-64 text-center">
        <div className="space-y-2">
          <p className="text-muted-foreground">No notes yet</p>
          <p className="text-sm text-muted-foreground">Click the + button to create your first note</p>
        </div>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 gap-4 p-4">
      {notes.map((note) => (
        <NoteCard
          key={note.id}
          note={note}
          onEdit={onEditNote}
          onDelete={onDeleteNote}
        />
      ))}
    </div>
  );
}