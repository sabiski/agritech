-- Création de la table des profils
create table if not exists public.profiles (
    id uuid references auth.users on delete cascade,
    full_name text,
    role text check (role in ('farmer', 'customer', 'supplier', 'admin', 'delivery')),
    phone_number text,
    address text,
    profile_picture_url text,
    business_name text,
    business_type text,
    created_at timestamp with time zone default timezone('utc'::text, now()),
    updated_at timestamp with time zone default timezone('utc'::text, now()),
    primary key (id)
);

-- Suppression des politiques existantes
drop policy if exists "Les utilisateurs peuvent voir leur propre profil" on public.profiles;
drop policy if exists "Les utilisateurs peuvent mettre à jour leur propre profil" on public.profiles;
drop policy if exists "Les admins peuvent tout voir" on public.profiles;

-- Création des politiques de sécurité Row Level Security (RLS)
alter table public.profiles enable row level security;

create policy "Les utilisateurs peuvent voir leur propre profil"
    on public.profiles for select
    using ( auth.uid() = id );

create policy "Les utilisateurs peuvent mettre à jour leur propre profil"
    on public.profiles for update
    using ( auth.uid() = id );

create policy "Les admins peuvent tout voir"
    on public.profiles for all
    using ( auth.uid() in (
        select id from public.profiles where role = 'admin'
    ));

-- Fonction pour gérer la création automatique des profils
create or replace function public.handle_new_user()
returns trigger as $$
begin
    insert into public.profiles (
        id,
        full_name,
        role,
        phone_number,
        address,
        business_name,
        business_type
    )
    values (
        new.id,
        new.raw_user_meta_data->>'full_name',
        coalesce(new.raw_user_meta_data->>'role', 'customer'),
        new.raw_user_meta_data->>'phone_number',
        new.raw_user_meta_data->>'address',
        new.raw_user_meta_data->>'business_name',
        new.raw_user_meta_data->>'business_type'
    );
    return new;
end;
$$ language plpgsql security definer;

-- Suppression du trigger s'il existe déjà
drop trigger if exists on_auth_user_created on auth.users;

-- Création du trigger
create trigger on_auth_user_created
    after insert on auth.users
    for each row execute procedure public.handle_new_user();

-- Fonction pour mettre à jour le timestamp
create or replace function public.handle_updated_at()
returns trigger as $$
begin
    new.updated_at = now();
    return new;
end;
$$ language plpgsql;

-- Trigger pour mettre à jour le timestamp
create trigger on_profile_updated
    before update on public.profiles
    for each row execute procedure public.handle_updated_at(); 