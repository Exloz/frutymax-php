import { type SharedData } from '@/types';
import { Head, Link, usePage } from '@inertiajs/react';

export default function Welcome() {
    const { auth } = usePage<SharedData>().props;

    return (
        <div className="flex h-screen items-center justify-center">
            <Head title="Welcome" />
            <div className="text-center">
                <h1 className="text-4xl font-bold">Welcome to our application!</h1>
            </div>
        </div>
    );
}
